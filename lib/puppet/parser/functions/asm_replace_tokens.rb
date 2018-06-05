require "net/http"
require "shellwords"

#This is a custom puppet function that takes an encrypted password string and decrypts it
module Puppet::Parser::Functions
  newfunction(:asm_replace_tokens, :type => :rvalue) do |args|
    cmd = args[0]

    # check what characters tokens can have, this only handles alphanumeric
    tokens = cmd.scan(/(ASMTOKEN-[0-9a-zA-Z-]+)/).flatten.uniq

    puts "==============> [GS] tokens = %s" % tokens.join(", ")

    # passwords = tokens.map do |token|
    #   #cert_name = puppet config print node_name_value
    #   cert_name = "agent-svm-aer11-host-c1" # find puppet variable to get this, or shell out if we have to
    #   path = "/asm/secret/tokencred/%s?token_key=%s" % [cert_name, token]
    #   Net::HTTP.get("http://dellasm:8080", path)
    # end

    passwords = tokens.map { |token| "DECRYPTED-%s" % token }

    tokens.each_with_index do |token, i|
      password = passwords[i]
      cmd = cmd.gsub(token, Shellwords.escape(password))
    end

    cmd
  end
end
