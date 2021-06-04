import itertools


def recursive(dep_dict, tuple, seen=[]):
    circles = []
    if tuple[0] in seen:
        circles.append(seen[seen.index(tuple[0]):])
        seen = []
    else:
        seen.append(tuple[0])
        if tuple[1]:
            for item in tuple[1]:
                circles.extend(
                    recursive(dep_dict, [item, dep_dict.get(item)], seen.copy())
                )
    return circles


def find_circular_dependencies(dep_dict):
    circles = []
    for key in dep_dict:
        circles.extend(recursive(dep_dict, [key, dep_dict[key]], []))
    for i in range(len(circles)):
        circles[i].sort()
    circles.sort()
    circles_without_duplicates = list(k for k, _ in itertools.groupby(circles))
    return circles_without_duplicates
