import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

class DatasourceGenerator extends GeneratorForAnnotation<Datasource> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final classElement = element as ClassElement;
    final className = classElement.name;
    final baseName = className.replaceAll('Model', '');
    final modelName = className;

    final methodName = annotation.read('methodName').stringValue ?? 'get$baseName';
    final paramName = annotation.read('paramName').stringValue ?? '${baseName.toLowerCase()}Id';
    final paramType = annotation.read('paramType').stringValue ?? 'int';

    // Abstract datasource
    final abstractDatasourceCode = '''
abstract class ${baseName}RemoteDatasource {
  Future<$modelName?> $methodName({
    required $paramType $paramName,
  });
}
''';

    // Datasource implementation
    final datasourceImplCode = '''
import 'package:injectable/injectable.dart';

import '../../../../config/tmdb_api/tmdb_api.dart';
import '../model/$modelName.dart';

@LazySingleton(as: ${baseName}RemoteDatasource)
class ${baseName}RemoteDatasourceImpl implements ${baseName}RemoteDatasource {
  @override
  Future<$modelName?> $methodName({
    required $paramType $paramName,
  }) async {
    try {
      final result = await TmdbApi.tmdbWithCustomLogs.v3.${baseName.toLowerCase()}
          .${methodName}(
           $paramName,
          );
      return $modelName.fromJson(
        result as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
''';

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion
    );
    return formatter.format('$abstractDatasourceCode\n$datasourceImplCode');
  }
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