### block 1
MATCH (n) RETURN count(n);
CREATE (a:Test {name: 'foo'}) RETURN a;

### block 2
MATCH (a:Test) SET a.processed = true RETURN a;
