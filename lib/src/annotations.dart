library clean_archx;

class Entity {
  const Entity();
}

class Repository {
  final String methodName;
  final String paramName;
  final String paramType;

  const Repository({
    this.methodName = 'get',
    this.paramName = 'id',
    this.paramType = 'int',
  });
}

class Datasource {
  final String methodName;
  final String paramName;
  final String paramType;

  const Datasource({
    this.methodName = 'get',
    this.paramName = 'id',
    this.paramType = 'int',
  });
}

class Usecase {
  final String methodName;
  final String paramName;
  final String paramType;

  const Usecase({
    this.methodName = 'get',
    this.paramName = 'id',
    this.paramType = 'int',
  });
}

class Bloc {
  final String paramName;
  final String paramType;

  const Bloc({
    this.paramName = 'id',
    this.paramType = 'int',
  });
}