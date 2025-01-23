//10.--------------------------------------
void main() {
  Map map1 = {
    'a': 1,
    'b': {
      'c': 2,
      'd': {'e': 3},
    },
  };

  Map map2 = {
    'b': {
      'c': 4,
      'd': {'f': 5},
    },
    'g': 6,
  };
  Map mergedMap = mergeMaps(map1, map2);
  print(mergedMap);
}

Map mergeMaps(Map map1, Map map2) {
  Map result = {};
  map1.forEach((key, value) {
    if (map2[key] != null) {
      if (value is Map && map2[key] is Map) {
        result[key] = mergeMaps(value, map2[key]);
      } else if (value is int && map2[key] is int) {
        result[key] = value + map2[key];
        
      }
    } else {
      result[key] = value;

    }
  });

  map2.forEach((key, value) {
    if (result[key] == null) {
      result[key] = value;

    }
  });

  return result;
}

