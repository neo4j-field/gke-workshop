#!/usr/bin/env python3
import argparse
import json
import random
import threading
import time
from collections import defaultdict

from neo4j import GraphDatabase


def load_users(path):
    with open(path) as f:
        return json.load(f)


def load_query_blocks(path):
    blocks = []
    name = None
    current = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith("###"):
                if name and current:
                    blocks.append((name, current))
                name = line[3:].strip()
                current = []
            elif line and not line.startswith("//"):
                current.append(line.rstrip(";"))
        if name and current:
            blocks.append((name, current))
    return blocks


def run_user(user_conf, uri, blocks, iterations, results, lock):
    print(f"Starting for user {user_conf['user']}")
    auth = (user_conf["user"], user_conf["password"])
    driver = GraphDatabase.driver(uri, auth=auth)
    stats = defaultdict(list)
    errors = []
    for iteration in range(iterations):
        print(f"Starting for user {user_conf['user']} iteration: {iteration}")
        for name, block in blocks:
            start = time.perf_counter()
            try:
                with driver.session(database=user_conf["database"]) as session:
                    for q in block:
                        session.run(q).consume()
            except Exception as e:
                errors.append((name, str(e)))
            else:
                elapsed = time.perf_counter() - start
                stats[name].append(elapsed)
            time.sleep(random.uniform(30, 120))
    driver.close()
    with lock:
        results[user_conf["user"]] = {"stats": stats, "errors": errors}


def summarize(results):
    overall = defaultdict(list)
    print("\n=== Load Test Summary ===\n")
    for user, data in results.items():
        print(f"User {user}:")
        for name, times in data["stats"].items():
            mn, mx = min(times), max(times)
            avg = sum(times) / len(times)
            print(f"  {name}: min={mn:.3f}s, max={mx:.3f}s, avg={avg:.3f}s")
            overall[name].extend(times)
        if data["errors"]:
            print(f"  Errors ({len(data['errors'])}):")
            for nm, msg in data["errors"]:
                print(f"    {nm}: {msg}")
        print()
    print("=== Aggregate across all users ===")
    for name, times in overall.items():
        mn, mx = min(times), max(times)
        avg = sum(times) / len(times)
        print(f"  {name}: min={mn:.3f}s, max={mx:.3f}s, avg={avg:.3f}s")
    print()


def main():
    p = argparse.ArgumentParser(
        description="Workshop Cypher load tester"
    )
    p.add_argument("-a", "--uri", required=True,
                   help="Bolt URL, e.g. bolt://localhost:7687")
    p.add_argument("-u", "--users", required=True,
                   help="Path to users.json")
    p.add_argument("-q", "--queries", required=True,
                   help="Path to queries.cql")
    p.add_argument("-n", "--iterations", type=int, default=1,
                   help="Iterations per user")
    args = p.parse_args()

    users = load_users(args.users)
    blocks = load_query_blocks(args.queries)

    threads = []
    results = {}
    lock = threading.Lock()
    for u in users:
        t = threading.Thread(
            target=run_user,
            args=(u, args.uri, blocks, args.iterations, results, lock),
            daemon=True
        )
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    summarize(results)


if __name__ == "__main__":
    main()
