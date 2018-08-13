---
layout: post
title: GPG Transition Statement
author: Clément Durand
---

The original signed transition statement is available
[here](/publickey/transition.20180813.txt.asc),
[here](https://keybase.pub/neze/transition.20180813.txt.asc) or even
[here](https://gist.github.com/w2ak/38b1bc1e9908d83d0672ba1853358184).

Signatures can be verified by `gpg --verify transition.20180813.txt.asc`.

---

Mon Aug 13 12:03:33 JST 2018

For a number of reasons, I've set up a new PGP key for my e-mail address
`<clement[at]neze[dot]fr>`, and will be transitioning this ID away from my
old key.

The old key will continue to support the ID for some time but I would
rather all future correspondance to come to the new one. I would also like
this new key to be re-integrated into the web of trust. This message is
signed by both keys to certify the transition.

The old key was:

```
pub   rsa3744/0x15247DF0CB359C59 2016-10-02
      Key fingerprint = 9646 DC24 1946 7375 C6B5  9DEE 1524 7DF0 CB35 9C59
sub   rsa2048/0x2F1F95F7738D7D23 2016-10-02
sub   rsa2048/0xB1426D0D5FE763A7 2016-10-02
sub   rsa2048/0x74C6A36D0333EC45 2016-10-02
```

And the new key is:

```
pub   nistp521/0xEF2D00C6CAA88D40 2017-10-28
      Key fingerprint = 1144 A011 11B4 FB8A 179B  5B67 EF2D 00C6 CAA8 8D40
sub   nistp521/0x41CF2D0211BAB362 2017-10-28
sub   nistp521/0x83253CC3161D3A90 2017-10-28
sub   nistp521/0x85A38C3277EC96AA 2017-10-28
```

To fetch the new key, you can get it with one of the following methods:

  * Get it from a key server.

    ```
    gpg --recv-keys CAA88D40
    ```

  * Get it from my server.

    ```
    curl -Ls https://www.neze.fr/CAA88D40.txt | gpg --import
    ```

  * Get it from Keybase.

    ```
    curl -Ls https://keybase.io/neze/pgp_keys.asc | gpg --import
    ```
    ```
    keybase pgp pull neze
    ```

If you already knew my old key, you can now verify that the new one is signed
by the old one.

```
gpg --check-sigs CAA88D40
```

If you do not know my old key or just want to be double extra paranoid, you
can check the fingerprint against the above.

```
gpg --fingerprint CAA88D40
```

If you are satisfied that you've got the right key and it corresponds to the
right person, I'd appreciate it if you would sign my key.

```
gpg --sign-key CAA88D40
```

Then, please make your signature available by the method of your choice. My
prefered method would be that you send me the newly signed key by e-mail so
that I can update the web of trust myself.

```
gpg --armor --export CAA88D40
```

Please let me know if there is any trouble, or if you need anything more, and
sorry for the inconvenience.

Regards,

Clement Durand
@neze
