### Basic Cypher
MATCH (m:Method {name:"checkPointer"}) RETURN m;
MATCH (:Method {name:"checkPointer"})-[:HAS]->(p:Parameter) RETURN p;
MATCH path = (:Method {name:"checkPointer"})-[:HAS]->(:Parameter) RETURN path;
MATCH (:Method {name:"checkPointer"})<-[:INVOKES]-(other:Method) RETURN other.name AS name;
MATCH path = (:Method {name:"checkPointer"})-[:HAS]->(p:Parameter)-[:OF_TYPE]->(:Type) RETURN path;
MATCH path = (:Method {name:"checkPointer"})-[:HAS]->(p:Parameter)-[:OF_TYPE]->(:Type {fqn:"long"}) RETURN path;


### variable length
MATCH path=(:Jar {fileName:'/neo4j-bolt-connection-pooled-1.1.0.jar'})-[:CONTAINS*]->(:Class) RETURN path;
MATCH path=(:Jar {fileName:'/neo4j-bolt-connection-pooled-1.1.0.jar'})-[:CONTAINS*3..7]->(:Class) RETURN path;
MATCH path=(:Jar {fileName:'/neo4j-bolt-connection-pooled-1.1.0.jar'}) (()-[:CONTAINS]->()){3,7} (:Class) RETURN path;
MATCH path=(c1:Class)-[:DECLARES]->()-[depends:INVOKES|READS|WRITES]->()<-[:DECLARES]-(c2:Class) WHERE c1 <> c2 WITH c1.fqn AS Class1, c2.fqn AS Class2, type(depends) AS kind, count(*) AS cnt WHERE cnt > 3 RETURN Class1, Class2, kind, cnt ORDER BY size(Class1 + Class2)  ASC LIMIT 10;
MATCH path=(c1:Class)-[:DECLARES]->()-[depends:INVOKES|READS|WRITES]->()<-[:DECLARES]-(c2:Class)   WHERE c1.fqn = 'org.neo4j.driver.Query' AND c2.fqn = 'org.neo4j.driver.Values' RETURN path;
MATCH (j1:Jar)-[:CONTAINS*]->(c1:Class)<-[:DEPENDS_ON]-(c2:Class)<-[:CONTAINS*]-(j2:Jar) WHERE j1 <> j2 RETURN j1.fileName, count(DISTINCT j2) AS cnt ORDER by cnt DESC limit 10;

