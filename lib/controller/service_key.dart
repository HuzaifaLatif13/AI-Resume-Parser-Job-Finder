import 'package:googleapis_auth/auth_io.dart';

class ServiceKey {
  Future<String> getServiceKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "resume-3cf51",
        "private_key_id": "c3a5a5e28cd5c0eee0ba3a65c19f92b7bc326b98",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCv9oMxKrMpuFoF\nB79qrj79sG83WguCgnn1iqnSFgudpwJ5yBXAJ0JN9HENGnXNp1ZDXcc2M3sDuPEG\nJfOQGtbPhsNEnKmPhC6gtU0NVxisLkxmjm4RhxQclH5vjDp6zF667e+MlTPLB77R\n7rci8/Va7tGNnZt7PheYERK/jXv7B3jAXQUB1vtP5DpjmGW6eVSzbl4XQLjOtbNN\nE4LwL/YOxgS9VNJb4Eqg0IYKsEPN/jwSeyGY49bIimVEqPM0nai5a9meuaVpzBUn\nsyAUOqTbvq7hTuI8bAsJaXYBSdIlrJ+w6nza24DFTsfWM7+YDiemWc/QRF6t1MFr\nFDG7C+zxAgMBAAECggEAAokIkKIlIL/UQn8CP4lFCBLx7Dsf1J2UyuMPaM2qLZvr\n6PLCqjqlDgo+zYIsEQ/92rEm2pLmyhoz5FgAEcq593b5uti0Poieeb/fLIDdfeDW\n5QN7cBRO/pBsfghVzGqG4jiP7y/e3QzmNYpGRszcztOHWOOl8ve0j49RISVejjKb\n/o2QojMyUn6yunggmiq/g+nJ5kcb5sa8ffnjCh/xaQXyCejJ7UuehXU8rj37KbNU\ncGiWyGL8Ig+0ZNPiyATvkq6R5Usf/EayBumg5xvQmIKFLiLOJv+oPpMg6SOGPZp3\nDekWl5MUoc0yUtQAGIqDhjYDrndzuev2oSbMahZJxwKBgQDs7x/O04KF7fFuCYZN\nQ0qi37HthQMvRuFzmelNmjk+5exjUzb9WNLZuiFBCqUodO1gzFu2oCRQHuRkjc7C\nWWlJlh5xGqT7uPLCP+qGAOQjHP14TGpbeAz8nxf/JoODFz0QHGLOQWJhYs90VtA1\namJnQULpbfwKfqiSzptaV6tg8wKBgQC+H1/CkGo5rgWZa+S10uxR3joeRwYpnt5U\nbxWPl+Mgu/k5WOBxpxTmrZJOlcgzTGjVQFTW5mAlyt1mKmfI3ZrlzZYGknT5Rp8B\nH4hBrJX7V0MYT3QSmpgn+PG6LDCugSnREwrNZcKgy3u1r1BChC8KwquiMrlyNWOV\nqRDidRLTiwKBgQCq9X/GBOfRK3dhJo45gayBCVehQrChlEto1k15KSbVM6H1qT2s\nYEMDx0HnZH73SideCRbEF5kcFq5Fv+zIXyuRZThh9A/HchP4BZZ7SnlSvMBH5Rt5\nFI6KWWE/QdLy6/mrfk/s81DBZEK8d0eUw0ZtqrFVLX8HM4z/IQUHkuqd8QKBgDWZ\nSrnjVM8mDFYQYM4RxKXf7KqUg1xAeZV8K6vruhCEbeKI992SqQXPcSvOdj5gED3u\ngPyEvh5pbrlawx+RuhWHPABmUavlCPacGSHKsg3FsBiubZ7BDpxWRm+h/ad0qoFS\nyPzW72O9egbigdH+yfRSpWh4vGdCPez3WNc/Aiu5AoGBAIraHk0dTUBFgNI/emln\nUlZ72UYWxgUvxA23frskem4nwson8Jhlkq6/JXJgwcaJ7J3DRsHUqbXyIyXZjyzn\nE/KeVELq0XE2Z4MqkHHwdfhAosH6zTLRKhQOxX+OjXwE4AXKLOaRdQd57REgOCcr\nzzzqPF/ZOQQRyT1NoDxTkn1B\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@resume-3cf51.iam.gserviceaccount.com",
        "client_id": "103190695971886324103",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40resume-3cf51.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );

    final accessToken = await client.credentials.accessToken.data;
    return accessToken;
  }
}
