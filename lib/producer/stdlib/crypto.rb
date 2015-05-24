require 'openssl'
require 'securerandom'

module Producer
  module STDLib
    module Crypto
      STDLib.define_macro :cert_write do |path, cn, issuer_path, ikey_path|
        name    = OpenSSL::X509::Name.parse("CN=#{cn}")
        issuer  = OpenSSL::X509::Certificate.new(File.read(issuer_path))
        ikey    = OpenSSL::PKey::RSA.new(File.read(ikey_path))
        key     = OpenSSL::PKey::RSA.new(4096)

        cert = OpenSSL::X509::Certificate.new
        cert.serial      = SecureRandom.random_number(2 ** 159)
        cert.version     = 2
        cert.not_before  = Time.now
        cert.not_after   = Time.now + 20 * 365 * 86400
        cert.public_key  = key.public_key
        cert.subject     = name
        cert.issuer      = issuer.subject

        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate  = issuer
        cert.extensions = [
          ef.create_extension('subjectKeyIdentifier', 'hash'),
          ef.create_extension('basicConstraints', 'CA:FALSE'),
          ef.create_extension(
            'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature'
          )
        ]

        cert.sign ikey, OpenSSL::Digest::SHA512.new

        file_write path, cert.to_pem + key.to_pem, mode: 0600
      end
    end
  end
end
