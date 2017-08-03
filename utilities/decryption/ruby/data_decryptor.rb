require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'json'
require 'pry'
require 'base64'

class DataDecryptor

  CIPHER = 'AES-128-CBC'
  VERSION = '1.0'

  def self.parse(args)
    options = OpenStruct.new
    options.cipher = CIPHER
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "\nCan decrypt GE_PARTNER_DATA\n\nUsage: data_decryptor.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-f", "--file FILE",
              "Path to the file to decrypt") do |file_path|
        options.file_path = file_path
        unless File.exist? file_path
          error "Bad file at #{file_path}"
        end
      end

      # Mandatory argument.
      opts.on("-kKEY", "--key KEY",
              "Path to the private key file") do |key_path|
        options.key_path = key_path
        unless File.exist? key_path
          error "Bad file at #{file_path}"
        end
      end

      # opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      #   options.verbose = v
      # end

      opts.on("-c", "--cipher CIPHER", "Which cipher to use, defaults to #{CIPHER}") do |c|
        options.cipher = c
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts VERSION
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end

  def self.process(options)
    if options.key_path.nil?
      error("No key file detected at #{options.key_path}")
      exit
    end
    private_key = OpenSSL::PKey::RSA.new(File.read(options.key_path))  rescue error("Private file is not valid")
    f=File.open(options.file_path,"r") do |f|
      f.each_line do |line|
        json = JSON.parse line
        if json["eid"] == "GE_PARTNER_DATA"
          eks = json["edata"]["eks"]
          data = eks["data"]
          iv = eks["iv"]
          encrypted_string = eks["key"]
          key = private_key.private_decrypt(Base64.decode64(encrypted_string)) rescue error("Unable to decrypt! Check private file.")
          data = Base64.decode64(data)
          iv = Base64.decode64(iv)
          aes  = OpenSSL::Cipher.new(CIPHER)
          aes.decrypt
          aes.key = key
          aes.iv = iv
          data = aes.update(data) + aes.final
          data = JSON.parse data
          puts data
        end
      end
    end
  end

  def self.error(msg)
    puts "ERROR! #{msg}"
    exit
  end

end

options = DataDecryptor.parse(ARGV)
DataDecryptor.process(options)
