import os
import logging
from neo4j import GraphDatabase, basic_auth

# Silence verbose Neo4j driver logs
logging.getLogger('neo4j').setLevel(logging.INFO)
logging.getLogger('neo4j.io').setLevel(logging.INFO)

logger = logging.getLogger(__name__)

NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_AUTH = os.getenv("NEO4J_AUTH")
if not NEO4J_URI or not NEO4J_AUTH:
    raise RuntimeError("NEO4J_URI and NEO4J_AUTH must be set in environment variables")

NEO4J_USER, NEO4J_PASSWORD = NEO4J_AUTH.split('/', 1)
logger.info(f"Connecting to Neo4j: URI={NEO4J_URI}, User={NEO4J_USER}")

# Global driver
driver = GraphDatabase.driver(
    NEO4J_URI,
    auth=basic_auth(NEO4J_USER, NEO4J_PASSWORD)
)
