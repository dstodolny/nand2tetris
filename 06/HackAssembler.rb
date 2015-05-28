#!/usr/bin/env ruby

DEST = { nil => "000", "M" => "001", "D" => "010", "MD" => "011",
         "A" => "100", "AM" => "101", "AD" => "110", "AMD" => "111" }

COMP = { "0" => "0101010", "1" => "0111111", "-1" => "0111010",
         "D" => "0001100", "A" => "0110000", "!D" => "0001101",
         "!A" => "0110001", "-D" => "0001111", "-A" => "0110011",
         "D+1" => "0011111", "A+1" => "0110111", "D-1" => "0001110",
         "A-1" => "0110010", "D+A" => "0000010", "D-A" => "0010011",
         "A-D" => "0000111", "D&A" => "0000000", "D|A" => "0010101",
         "M" => "1110000", "!M" => "1110001", "-M" => "1110011",
         "M+1" => "1110111", "M-1" => "1110010", "D+M" => "1000010",
         "D-M" => "1010011", "M-D" => "1000111", "D&M" => "1000000",
         "D|M" => "1010101" }

JUMP = { nil => "000", "JGT" => "001", "JEQ" => "010",
         "JGE" => "011", "JLT" => "100", "JNE" => "101",
         "JLE" => "110", "JMP" => "111" }


# Encapsulates access to the input code
class Parser
  attr_reader :file, :current_command

  def initialize(filename)
    @file = File.open(filename, "r")
    @current_command = ""
  end

  def no_more_commands?
    file.eof?
  end

  def advance
    loop do
      @current_command = file.readline.split("//").first.strip
      break unless @current_command.empty? && !no_more_commands?
    end
  end

  def command_type
    if @current_command[0] == "@"
      "A_COMMAND"
    elsif @current_command[0] == "("
      "L_COMMAND"
    else
      "C_COMMAND"
    end
  end

  def symbol
    @current_command.delete("@()")
  end

  def dest
    @current_command.split(";").first.split("=").first
  end

  def comp
    @current_command.split(";").first.split("=")[1]
  end

  def jump
    return nil unless @current_command.include?(";")
    @current_command.split(";").last
  end
end

filename = ARGV.first
p = Parser.new(filename)

target = File.open(filename.split(".").first + ".hack", "w")


until p.no_more_commands?
  p.advance
  if p.command_type == "C_COMMAND"
    target.write("111" + COMP[p.comp] + DEST[p.dest] + JUMP[p.jump])
  else
    target.write("%016b" % p.symbol.to_i)
  end
  target.write("\n")
end
target.close

