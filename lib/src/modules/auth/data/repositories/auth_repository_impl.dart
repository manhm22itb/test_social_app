

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final SupabaseClient supabaseClient;
  AuthRepositoryImpl(this.authRemoteDataSource, this.supabaseClient);

  @override
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password})async{
    try{
      final userEntity = await authRemoteDataSource.signIn(email: email, password: password);
      return Right(userEntity);
    } on Exception catch(e){
      if (e.toString().contains('Invalid login credentials')) {
        return Left(AuthFailure('Invalid login credentials'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return authRemoteDataSource.signInWithGoogle();
  }


  @override
  Future<Either<Failure, UserEntity>> signUp({required String email, required String password}) async {
    try {
      

      final userEntity = await authRemoteDataSource.signUp(email: email, password: password);
      return Right(userEntity);
    } on Exception catch(e) {
      print('Repository Exception: ${e.toString()}');
      
          return Left(AuthFailure(e.toString()));
    }
  }


  @override
  Future<Either<Failure, void>> signOut() async{
    try{
      await authRemoteDataSource.signOut();
      return const Right(null);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async{
    try{
      await authRemoteDataSource.resetPassword(email: email);
      return Right(null);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  // listen oauth
  Stream<UserEntity?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((response) {
      
      final user = response.session?.user;
      if (user == null) {
        return null; 
      }
      return UserEntity(
        id: user.id,
        email: user.email!,
        username: user.userMetadata?['username'] as String?,
      );
    }).handleError((e) {
      print('Auth Stream Error: $e');
      return null;
    });
  }
  
  @override
  Future<Either<Failure, void>> updatePasswprd({required String newPassword}) async {
    try{
      await authRemoteDataSource.updatePassword(newPassword: newPassword);
      return Right(null);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getUserInfo() async {
    try{
      final user = await authRemoteDataSource.getUserInfo();
      return Right(user);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }
  
  
}