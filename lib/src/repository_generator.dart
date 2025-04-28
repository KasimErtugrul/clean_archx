import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

class RepositoryGenerator extends GeneratorForAnnotation<Repository> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final classElement = element as ClassElement;
    final className = classElement.name;
    final baseName = className.replaceAll('Model', '');
    final entityName = '${baseName}Entity';
    final modelName = className;

    final methodName = annotation.read('methodName').stringValue ?? 'get$baseName';
    final paramName = annotation.read('paramName').stringValue ?? '${baseName.toLowerCase()}Id';
    final paramType = annotation.read('paramType').stringValue ?? 'int';

    // Abstract repository
    final abstractRepoCode = '''
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_request.dart';
import '../entity/$entityName.dart';

abstract class ${baseName}Repository {
  Future<Either<Failure, $entityName?>> $methodName({
    required $paramType $paramName,
  });
}
''';

    // Repository implementation
    final repoImplCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:your_package/core/di/di.dart';

import '../../../../core/error/failure_request.dart';
import '../../../../core/error/service_exception.dart';
import '../repository/${baseName.toLowerCase()}_repository.dart';
import '../entity/$entityName.dart';
import '../datasource/${baseName.toLowerCase()}_remote_datasource.dart';

@LazySingleton(as: ${baseName}Repository)
class ${baseName}RepositoryImpl implements ${baseName}Repository {
  final ${baseName}RemoteDatasource remoteDatasource = getIt.get();

  @override
  Future<Either<Failure, $entityName?>> $methodName({
    required $paramType $paramName,
  }) async {
    try {
      final result = await remoteDatasource.$methodName(
        $paramName: $paramName,
      );
      return Right(result);
    } on ServiceException catch (failure) {
      return Left(ServiceFailure(failure.errorHandle.statusMessage));
    }
  }
}
''';

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion
    );
    return formatter.format('$abstractRepoCode\n$repoImplCode');
  }
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