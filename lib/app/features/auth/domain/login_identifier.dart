/// Turns what the person typed on the sign-in page into the e-mail Supabase
/// Auth expects (decision 66).
///
/// - A value with `@` is a full e-mail (some accounts, such as `admin`, are
///   registered under a real address) and is used as typed.
/// - Anything else is a username: `<username>@<domain>`. GoTrue stores e-mails
///   in lower case, so the username is lower-cased to match whatever case the
///   person typed.
///
/// The result is never shown; the person only ever sees the username.
String resolveLoginEmail(String identifier, {required String domain}) {
  final value = identifier.trim();
  if (value.contains('@') || domain.isEmpty) return value;
  return '${value.toLowerCase()}@$domain';
}
