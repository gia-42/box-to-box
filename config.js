// Box to Box settings. This is the only file you edit to turn on accounts and friends.
// Leave supabaseUrl empty and the game still works, with stats saved on each device only.
window.B2B_CONFIG = {
  supabaseUrl: "https://ucbiisgpmfxdriwzirmh.supabase.co",        // e.g. "https://abcdefgh.supabase.co"
  supabaseAnonKey: "sb_publishable_kHpxPPAMKsWEyuFj5kS87Q_JvEocltc",    // the "publishable" key, starts with sb_publishable_
  googleClientId: "",     // e.g. "1234-abc.apps.googleusercontent.com"

  // Login buttons to show. Email login is always on.
  providers: {
    google: true,
    apple: false
  }
};
