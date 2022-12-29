import 'package:fpdart/fpdart.dart';
import 'package:sorun_takip_sistemi/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
