# Copyright 2015 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'formula'

class Xpra < Formula
  homepage 'https://www.xpra.org'
  head 'https://www.xpra.org/svn/Xpra/trunk/src', :using => :svn

  url 'https://www.xpra.org/src/xpra-0.14.29.tar.xz'
  version '0.14.29'
  sha256 'bb46a25485f29ae2f99cf8705525fa73b90d28fe84d4172d58a90d959e59b0b0'

  devel do
    url 'https://www.xpra.org/src/xpra-0.15.5.tar.xz'
    sha256 'bcd258e8a0af4d074da09c898f0b80b5ea09513782184e06c6003f31365dfb9a'
  end

  depends_on 'pkg-config' => :build
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on 'gtk-mac-integration'
  depends_on 'Homebrew/python/pillow'

  resource 'cython' do
    url 'https://github.com/cython/cython/archive/0.24.tar.gz'
    sha256 'b60b91f1ec88921a423d5f0a5e2a7c232cdff12d9130088014bf89d542ce137b'
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec/'vendor/lib/python2.7/site-packages'
    resource('cython').stage do
      system 'python', *Language::Python.setup_install_args(libexec/'vendor')
    end

    ENV.prepend_create_path 'PYTHONPATH', lib/'python2.7/site-packages'
    inreplace 'setup.py', 'sys.prefix', '"' + prefix + '"'
    system 'python',
           *Language::Python.setup_install_args(prefix),
           '--without-enc_x264', # makes dependency footprint much smaller
           '--without-server', '--without-shadow', # not supported anyway
           '--verbose' # more verbose for debugging
    # Homebrew does not create an app, this confuses directory detection
    (prefix/'lib/python2.7/site-packages/xpra/platform/darwin').
        install 'xpra/platform/xposix/paths.py'


    bin.env_script_all_files(libexec/'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test xpra`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system 'false'
  end
end
