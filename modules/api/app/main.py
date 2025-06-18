import csv
import io
import logging
import os
import re
import secrets
import sys
from io import BytesIO

import petname
from app.neo4j_client import driver
from app.security import verify_token
from flask import Flask, request, jsonify, Response
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer

# ─── Logging setup ─────────────────────────────────────────────────────────────
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

# suppress overly‐chatty logs from Neo4j driver
logging.getLogger('neo4j').setLevel(logging.INFO)
logging.getLogger('neo4j.io').setLevel(logging.INFO)

# ── verify connectivity on import ─────────────────────────────────────────
try:
    driver.verify_connectivity()
    logging.getLogger().info("Neo4j connectivity OK")
except Exception as e:
    logging.getLogger().critical(f"Neo4j connect failed: {e}")
    sys.exit(1)

app = Flask(__name__)

app.logger.setLevel(logging.DEBUG)


def _create_db_and_users(count, seed_uri):
    results = []
    template = [
        "CREATE OR REPLACE ROLE {role}",
        "GRANT ACCESS ON DATABASE {db}                      TO {role}",
        "GRANT MATCH {{*}}    ON GRAPH {db} NODE *          TO {role}",
        "GRANT MATCH {{*}}    ON GRAPH {db} RELATIONSHIP *  TO {role}",
        "GRANT WRITE        ON GRAPH {db}                   TO {role}",
        "GRANT NAME MANAGEMENT            ON DATABASE {db}  TO {role}",
        "GRANT SHOW CONSTRAINT            ON DATABASE {db}  TO {role}",
        "GRANT CONSTRAINT MANAGEMENT      ON DATABASE {db}  TO {role}",
        "GRANT SHOW INDEX                 ON DATABASE {db}  TO {role}",
        "GRANT INDEX MANAGEMENT           ON DATABASE {db}  TO {role}",
        "CREATE OR REPLACE USER {user} "
        "SET PASSWORD '{password}' CHANGE NOT REQUIRED "
        "SET HOME DATABASE {db}",
        "GRANT ROLE {role} TO {user}"
    ]
    with driver.session(database='system') as session:
        for i in range(1, count + 1):
            db = f"db{i:03}"
            user = f"u_{i:03}"
            role = f"r_{i:03}"
            pwd = f"{petname.Generate(2, '-')}-{secrets.randbelow(10)}"
            opts = f"OPTIONS {{seedURI:'{seed_uri}'}} " if seed_uri else ""
            session.run(
                f"CREATE DATABASE {db} IF NOT EXISTS TOPOLOGY 1 PRIMARY "
                f"{opts}WAIT 300 SECONDS"
            )
            for stmt in template:
                session.run(stmt.format(role=role, user=user, db=db, password=pwd))
            results.append({'user': user, 'password': pwd, 'database': db})
            app.logger.info(f"Created database and user for {user}")
    return results


def _csv_response(results):
    buf = io.StringIO()
    writer = csv.DictWriter(buf, fieldnames=['user', 'password', 'database'])
    writer.writeheader()
    writer.writerows(results)
    return Response(buf.getvalue(), mimetype='text/csv')


def _pdf_response(results):
    buf = BytesIO()
    doc = SimpleDocTemplate(
        buf,
        pagesize=letter,
        leftMargin=20, rightMargin=20,
        topMargin=20, bottomMargin=20
    )

    # compute usable width for full‐width tables
    usable_width = doc.width
    col_widths = [usable_width / 3] * 3

    font_size = 14
    padding = int(font_size * 0.6)  # ~8–9pt

    story = []
    for r in results:
        data = [
            ['User', 'Password', 'Database'],
            [r['user'], r['password'], r['database']]
        ]
        table = Table(data, colWidths=col_widths)
        table.setStyle(TableStyle([
            ('FONTSIZE', (0, 0), (-1, -1), font_size),
            ('TOPPADDING', (0, 0), (-1, -1), padding),
            ('BOTTOMPADDING', (0, 0), (-1, -1), padding),

            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#666666')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),

            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
        ]))

        story.append(table)
        story.append(Spacer(1, padding * 2))

    doc.build(story)
    buf.seek(0)
    return Response(
        buf.read(),
        mimetype='application/pdf',
        headers={'Content-Disposition': 'attachment; filename="users.pdf"'}
    )


@app.route('/create', methods=['POST'])
@verify_token
def create():
    payload = request.get_json(force=True)
    count = payload.get('count')
    seed_uri = payload.get('seed_uri')
    if not isinstance(count, int) or count < 1:
        return jsonify({'error': 'Invalid count'}), 400

    results = _create_db_and_users(count, seed_uri)

    accept = request.headers.get('Accept', '')
    if 'text/csv' in accept:
        return _csv_response(results)
    if 'application/pdf' in accept:
        return _pdf_response(results)
    return jsonify(results)


@app.route('/users', methods=['GET'])
@verify_token
def list_users():
    try:
        out = []
        with driver.session() as session:
            for rec in session.run('SHOW USERS YIELD user, home, roles'):
                out.append({
                    'user': rec['user'],
                    'database': rec.get('home'),
                    'roles': rec.get('roles')
                })

        if 'text/csv' in request.headers.get('Accept', ''):
            buf = io.StringIO()
            writer = csv.DictWriter(buf, fieldnames=['user', 'database', 'roles'])
            writer.writeheader()
            writer.writerows(out)
            return Response(buf.getvalue(), mimetype='text/csv')

        return jsonify(out)
    except Exception as e:
        app.logger.error(f"Exception in /users: {e}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/databases/count', methods=['GET'])
@verify_token
def count_dbs():
    try:
        with driver.session() as session:
            count = session.run(
                """
                SHOW DATABASES YIELD name
                WHERE name STARTS WITH 'db'
                RETURN COUNT(name) AS cnt
                """
            ).single()['cnt']
        return jsonify({'count': count})
    except Exception as e:
        app.logger.error(f"Exception in /databases/count: {e}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/user/<username>', methods=['DELETE'])
@verify_token
def delete_user(username):
    # only allow users named u_ followed by exactly three digits
    if not re.fullmatch(r'u_\d{3}', username):
        return jsonify({'error': 'Invalid username'}), 400

    suffix = username.split('_', 1)[-1]
    db = f"db{suffix}"
    role = f"r_{suffix}"

    app.logger.info(f"Deleting user {username}")

    templates = [
        "DROP USER {user} IF EXISTS",
        "DROP ROLE {role} IF EXISTS",
        "DROP DATABASE {db} IF EXISTS"
    ]

    with driver.session(database='system') as session:
        for stmt in templates:
            session.run(stmt.format(user=username, role=role, db=db))

    return jsonify({'status': 'deleted', 'user': username})


if __name__ == '__main__' and os.getenv('FLASK_ENV') != 'production':
    port = int(os.getenv('PORT', '5000'))
    app.logger.info(f"Starting Flask dev server on 0.0.0.0:{port}")
    app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)
