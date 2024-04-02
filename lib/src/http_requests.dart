part of db_agora_call;

bool isLogin = false;
String _token = "";

String setToken(String token) {
  isLogin = token.isEmpty ? false : true;
  _token = token;
  return _token;
}

Future post(String path, {body}) async {
  Uri uri = Uri.parse(path);
  var request = await http.post(uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: body);
  print("$path-${request.statusCode}: ${request.body}");
  if (request.statusCode == 400) {
    return jsonDecode(request.body);
  }

  if (request.statusCode != 201) {
    return;
  }

  return jsonDecode(request.body);
}

Future postJson(String path, {body}) async {
  try {
    Uri uri = Uri.parse(path);
    var request = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: body);

    if (request.statusCode == 400) {
      return jsonDecode(request.body);
    }

    if (request.statusCode != 200) {
      return;
    }

    return jsonDecode(request.body);
  } catch (e) {
    return;
  }
}

Future get(String path) async {
  Uri uri = Uri.parse(path);
  var request = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    },
  );

  if (request.statusCode != 200) {
    return;
  }

  return jsonDecode(request.body);
}

Future multipartPostRequest(
    String path,
    {File? file, required Map<String, String> body}) async {
  try {
    Uri uri = Uri.parse(path);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = "application/json"
      ..headers['Authorization'] = "Bearer $_token";

    request.fields.addAll(body);

    if (file != null) {
      request.files.add(http.MultipartFile.fromBytes(
          "image", file.readAsBytesSync(),
          filename: file.path.split("/").last));
    }
    var response = (await http.Response.fromStream(await request.send()));
    if (response.statusCode != 200) {
      return;
    }

    return jsonDecode(response.body);
  } catch (e) {
    return;
  }
}

Future filesMultipartPostRequest(
    String path,
    {Map<String, File> files = const {},
    required Map<String, String> body}) async {
  try {
    Uri uri = Uri.parse(path);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = "application/json"
      ..headers['Authorization'] = "Bearer $_token";

    request.fields.addAll(body);

    if (files.isNotEmpty) {
      files.forEach((key, file) {
        request.files.add(http.MultipartFile.fromBytes(
            key, file.readAsBytesSync(),
            filename: file.path.split("/").last));
      });
    }
    var response = (await http.Response.fromStream(await request.send()));
    if (response.statusCode != 200) {
      return;
    }

    return jsonDecode(response.body);
  } catch (e) {
    return;
  }
}
