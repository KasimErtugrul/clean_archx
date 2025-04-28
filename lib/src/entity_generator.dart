import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

class EntityGenerator extends GeneratorForAnnotation<Entity> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final classElement = element as ClassElement;
    final className = classElement.name;
    final entityName = '${className.replaceAll('Model', '')}Entity';

    final fields = classElement.fields
        .where((field) => field.isPublic && !field.isStatic)
        .map((field) {
      final type = field.type.getDisplayString(withNullability: true);
      final name = field.name;
      return 'final $type $name;';
    }).join('\n    ');

    final fromJsonParams = classElement.fields
        .where((field) => field.isPublic && !field.isStatic)
        .map((field) {
      final name = field.name;
      final type = field.type.getDisplayString(withNullability: false);
      return '$name: json["$name"] == null ? null : ${_getFromJsonConversion(type, name)}';
    }).join(',\n        ');

    final toJsonParams = classElement.fields
        .where((field) => field.isPublic && !field.isStatic)
        .map((field) {
      final name = field.name;
      return '"$name": $name';
    }).join(',\n        ');

    final props = classElement.fields
        .where((field) => field.isPublic && !field.isStatic)
        .map((field) => field.name)
        .join(', ');

    final code = '''
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class $entityName extends Equatable {
    $fields

    const $entityName({
        ${classElement.fields.where((field) => field.isPublic && !field.isStatic).map((field) => 'this.${field.name}').join(',\n        ')}
    });

    factory $entityName.fromJson(Map<String, dynamic> json) => $entityName(
        $fromJsonParams
    );

    Map<String, dynamic> toJson() => {
        $toJsonParams
    };

    @override
    List<Object?> get props => [$props];
}
''';

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion
    );
    return formatter.format(code);
  }

  String _getFromJsonConversion(String type, String name) {
    if (type.startsWith('List<')) {
      final innerType = type.substring(5, type.length - 1);
      return 'List<$innerType>.from(json["$name"]!.map((x) => ${innerType.replaceAll('?', '')}.fromJson(x)))';
    }
    return 'json["$name"] as $type';
  }
}

class Entity {
  const Entity();
}