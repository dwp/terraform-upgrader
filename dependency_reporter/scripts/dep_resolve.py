class ANSIColors:
    SUCCESS = '\033[0;32m'
    FAIL = '\033[0;31m'
    RESET = '\033[0m'


class Node:
    def __init__(self, name):
        self.name = name
        self.edges = []
        self.raw_edges = None

    def add_edge(self, node):
        self.edges.append(node)


def dep_resolve(node, resolved, seen):
    print(node.name)
    seen.append(node)
    for edge in node.edges:
        if edge not in resolved:
            if edge in seen:
                print(f"{ANSIColors.FAIL}Circular reference detected:{ANSIColors.RESET} {node.name} -> {edge.name} | path: {[x.name for x in seen[seen.index(edge):]]}.")
                continue
            dep_resolve(edge, resolved, seen)
    resolved.append(node)


def main():
    nodes = {}
    with open("./reports/deps.csv", "r") as reader:
        line = reader.readline()
        while line != '':
            line = reader.readline()[:-1]
            if line.count(",") == 2:
                node_name = line.split(",")[1]
                node = Node(node_name)
                node.raw_edges = "".join(line.split(",")[2:]).split(":") if not line.endswith(",") else []
                nodes[node_name] = node
    for k, v in nodes.items():
        if len(v.raw_edges) != 0:
            for e in v.raw_edges:
                edge = nodes.get(e)
                if edge:
                    v.add_edge(edge)

    resolve = []
    for node in nodes.values():
        seen = []
        print("-----------------------------")
        if node.edges:
            dep_resolve(node, resolve, seen)
        else:
            print(f"{ANSIColors.SUCCESS}{node.name} does not depend on other repos.{ANSIColors.RESET}")
        print("-----------------------------")
        print("\n")


if __name__ == "__main__":
    main()
