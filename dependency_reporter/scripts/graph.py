import os
import json

from neo4j import GraphDatabase


class Graph:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def load_repos_dependencies(self, dependencies_file_path):
        with self.driver.session() as session:
            session.write_transaction(self._create_repos_dependencies_as_vertices_and_edges, dependencies_file_path)

    @staticmethod
    def _create_repos_dependencies_as_vertices_and_edges(tx, dependencies_file_path):
        tx.run(
            f""" 
                LOAD CSV WITH HEADERS FROM "file:///{dependencies_file_path}" AS row
                MERGE (parent:Repo {{repoId: row.Id, repoName: row.repoName}})
                WITH parent, row
                UNWIND split(row.Dependencies, ":") AS dependency
                MATCH (child:Repo {{repoName: dependency}})
                MERGE (parent)-[d:HAS_DEPENDENCY]->(child)
            """)

    def query_graph(self, query_name):
        queries = {"circular_dependencies": self._query_circular_dependencies}
        with self.driver.session() as session:
            query = queries.get(query_name)
            if query:
                return session.write_transaction(query)

    @staticmethod
    def _query_circular_dependencies(tx):
        results = []
        response = tx.run(
            f""" 
                MATCH path = (n:Repo)<-[:HAS_DEPENDENCY*]-()
                RETURN path, size((n)<--()) AS count LIMIT 25
            """)
        for record in response:
            print(record.data())
            # WIP: Trying to understand how to parse and return the data
             # results.append(record)
            data = record.data()
            # results.append({data.get("path")[0].get("repoName"): data.get("path")[2].get("repoName")})
        # print(results)
        return results

    def close(self):
        self.driver.close()


def main():
    try:
        graph = Graph(os.environ.get("NEO4J_HOST", "bolt://localhost:7687"),
                      os.environ.get("NEO4J_USER", "neo4j"),
                      os.environ.get("NEO4J_PASSWORD", "neo4j"))
    except Exception as e:
        print(f"Error connecting, {e}")
    graph.load_repos_dependencies("deps.csv")
    graph.query_graph("circular_dependencies")
    graph.close()


if __name__ == '__main__':
    main()
