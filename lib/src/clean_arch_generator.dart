import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:clean_archx/src/entity_generator.dart';
import 'package:clean_archx/src/repository_generator.dart';
import 'package:clean_archx/src/datasource_generator.dart';
import 'package:clean_archx/src/usecase_generator.dart';
import 'package:clean_archx/src/bloc_generator.dart';

Builder cleanArchGenerator(BuilderOptions options) {
  return SharedPartBuilder(
    [
      EntityGenerator(),
      RepositoryGenerator(),
      DatasourceGenerator(),
      UsecaseGenerator(),
      BlocGenerator(),
    ],
    'clean_arch_generator',
  );
}