import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

class BlocGenerator extends GeneratorForAnnotation<Bloc> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final classElement = element as ClassElement;
    final className = classElement.name;
    final baseName = className.replaceAll('Model', '');
    final entityName = '${baseName}Entity';

    final paramName =
        annotation.read('paramName').stringValue ??
        '${baseName.toLowerCase()}Id';
    final paramType = annotation.read('paramType').stringValue ?? 'int';

    // Bloc file
    final blocCode = '''
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../entity/$entityName.dart';
import '../usecase/${baseName.toLowerCase()}_usecase.dart';

part '${baseName.toLowerCase()}_event.dart';
part '${baseName.toLowerCase()}_state.dart';

@Injectable()
class ${baseName}Bloc extends Bloc<${baseName}Event, ${baseName}State> {
  final ${baseName}Usecase ${baseName.toLowerCase()}Usecase = getIt.get();

  ${baseName}Bloc() : super(${baseName}State()) {
    on<${baseName}Event>((event, emit) async {
      try {
        var result = await ${baseName.toLowerCase()}Usecase.call(event.$paramName);
        result.fold(
          (l) => emit(state.copyWith(error: l.message)),
          (r) => emit(state.copyWith(data: r, loaded: true)),
        );
      } catch (e) {
        log('${baseName}Bloc Error');
      }
    });
  }
}
''';

    // Event file
    final eventCode = '''
part of '${baseName.toLowerCase()}_bloc.dart';

sealed class ${baseName}Event extends Equatable {
  final $paramType $paramName;

  const ${baseName}Event({required this.$paramName});

  @override
  List<Object> get props => [$paramName];
}
''';

    // State file
    final stateCode = '''
part of '${baseName.toLowerCase()}_bloc.dart';

class ${baseName}State extends Equatable {
  final $entityName? data;
  final bool loaded;
  final String error;

  const ${baseName}State({this.data, this.loaded = false, this.error = ''});

  @override
  List<Object?> get props => [data, loaded, error];

  ${baseName}State copyWith({
    $entityName? data,
    bool? loaded,
    String? error,
  }) {
    return ${baseName}State(
      data: data ?? this.data,
      loaded: loaded ?? this.loaded,
      error: error ?? this.error,
    );
  }
}
''';

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    return formatter.format('$blocCode\n$eventCode\n$stateCode');
  }
}

class Bloc {
  final String paramName;
  final String paramType;

  const Bloc({this.paramName = 'id', this.paramType = 'int'});
}
