class Acl2 < Formula
  desc "Logic and programming language in which you can model computer systems"
  homepage "https://www.cs.utexas.edu/users/moore/acl2/index.html"
  url "https://github.com/acl2/acl2/archive/refs/tags/8.5.tar.gz"
  sha256 "dcc18ab0220027b90f30cd9e5a67d8f603ff0e5b26528f3aab75dc8d3d4ebc0f"
  license "BSD-3-Clause"
  revision 21

  bottle do
    sha256 arm64_sequoia:  "c9d92ab8f2926598410e6f81df16d169f7846a389f70a05e5f972d464a1d97ee"
    sha256 arm64_sonoma:   "c36470d6d7f4bd9059f8582dbc9adb98fd3610c7970e24394a0eb91896ebb6e9"
    sha256 arm64_ventura:  "76085a6275d2d595c4f88ac564f604049e5becf9e85f615a03a47907e13e7057"
    sha256 arm64_monterey: "6c02b4ffe52882518925923f6ec373d5974425c7e491b4698de0a0f18bee9943"
    sha256 sonoma:         "72d61dec3596829644953e5d1cdb46204ec46937fa124b774920520425f2002a"
    sha256 ventura:        "eb2d0451c5547334bf4888590b6bb09310222100ef616ad9f3cb9d69af5ed11c"
    sha256 monterey:       "1e40324c3e8334462275731f4ff40bcffbe39c57669527148b36cd700e3bfbfa"
    sha256 x86_64_linux:   "60bf210af1e7fcc25f974dee291aef16618db2b6a097b5da1c730b53b93dda59"
  end

  depends_on "sbcl"

  def install
    # Remove prebuilt-binary.
    (buildpath/"books/kestrel/axe/x86/examples/popcount/popcount-macho-64.executable").unlink

    system "make",
           "LISP=#{HOMEBREW_PREFIX}/bin/sbcl",
           "ACL2=#{buildpath}/saved_acl2",
           "USE_QUICKLISP=0",
           "all", "basic"
    system "make",
           "LISP=#{HOMEBREW_PREFIX}/bin/sbcl",
           "ACL2_PAR=p",
           "ACL2=#{buildpath}/saved_acl2p",
           "USE_QUICKLISP=0",
           "all", "basic"
    libexec.install Dir["*"]

    (bin/"acl2").write <<~EOF
      #!/bin/sh
      export ACL2_SYSTEM_BOOKS='#{libexec}/books'
      #{Formula["sbcl"].opt_bin}/sbcl --core '#{libexec}/saved_acl2.core' --userinit /dev/null --eval '(acl2::sbcl-restart)'
    EOF
    (bin/"acl2p").write <<~EOF
      #!/bin/sh
      export ACL2_SYSTEM_BOOKS='#{libexec}/books'
      #{Formula["sbcl"].opt_bin}/sbcl --core '#{libexec}/saved_acl2p.core' --userinit /dev/null --eval '(acl2::sbcl-restart)'
    EOF
  end

  test do
    (testpath/"simple.lisp").write "(+ 2 2)"
    output = shell_output("#{bin}/acl2 < #{testpath}/simple.lisp | grep 'ACL2 !>'")
    assert_equal "ACL2 !>4\nACL2 !>Bye.", output.strip
  end
end
