import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

class UsecaseGenerator extends GeneratorForAnnotation<Usecase> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final classElement = element as ClassElement;
    final className = classElement.name;
    final baseName = className.replaceAll('Model', '');
    final entityName = '${baseName}Entity';

    final methodName = annotation.read('methodName').stringValue ?? 'get$baseName';
    final paramName = annotation.read('paramName').stringValue ?? '${baseName.toLowerCase()}Id';
    final paramType = annotation.read('paramType').stringValue ?? 'int';

    final usecaseCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/error/failure_request.dart';
import '../entity/$entityName.dart';
import '../repository/${baseName.toLowerCase()}_repository.dart';

@LazySingleton()
class ${baseName}Usecase extends BaseUseCase<$entityName?, $paramType> {
  final ${baseName}Repository repository = getIt.get();

  @override
  Future<Either<Failure, $entityName?>> call($paramType parameter) async {
    return await repository.$methodName($paramName: parameter);
  }
}
''';

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion
    );
    return formatter.format(usecaseCode);
  }
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