# TODOs

 * An API that accepts JSON encoded POST, PUT & PATCH requests should also require the Content-Type header be set to application/json or throw a 415 Unsupported Media Type HTTP status code.
 * check other webmachine concerns
 * pagination helpers
 * accept a request header X-HTTP-Method-Override with a string value containing one of PUT, PATCH or DELETE (only be accepted on POST requests)
 * 429 Too Many Requests
 * self.response.headers
 * 401 Unauthorized status code from the server (user name field of HTTP Basic Auth), add controller helpers
 * generating errors
