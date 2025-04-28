library clean_archx.annotations;

/// Entity sınıfı oluşturmak için kullanılır
class Entity {
  const Entity();
}

/// Repository katmanı oluşturmak için kullanılır
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

/// Datasource katmanı oluşturmak için kullanılır
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

/// Usecase katmanı oluşturmak için kullanılır
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

/// Bloc katmanı oluşturmak için kullanılır
class Bloc {
  final String paramName;
  final String paramType;

  const Bloc({
    this.paramName = 'id',
    this.paramType = 'int',
  });
}