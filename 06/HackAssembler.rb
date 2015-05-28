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
         "D|M" => "1010101", nil => "0000000" }

JUMP = { nil => "000", "JGT" => "001", "JEQ" => "010",
         "JGE" => "011", "JLT" => "100", "JNE" => "101",
         "JLE" => "110", "JMP" => "111" }


# Encapsulates access to the input code
class Parser
  attr_accessor :line
  attr_reader :file, :current_command

  def initialize(filename)
    @file = File.open(filename, "r")
    @current_command = ""
    @line = 0
  end

  def no_more_commands?
    file.eof?
  end

  def advance
    loop do
      @current_command = file.readline.split("//").first.strip
      break unless @current_command.empty? && !no_more_commands?
    end
    @line += 1
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
    return nil unless @current_command.include?("=")
    @current_command.split(";").first.split("=").first
  end

  def comp
    if @current_command.include?("=")
      @current_command.split(";").first.split("=")[1]
    else
      @current_command.split(";").first
    end
  end

  def jump
    return nil unless @current_command.include?(";")
    @current_command.split(";").last
  end

  def rewind
    @file.rewind
    @line = 0
  end
end

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

symbols = { "SP" => "0", "LCL" => "1", "ARG" => "2", "THIS" => "3",
            "THAT" => "4", "R0" => "0", "R1" => "1", "R2" => "2",
            "R3" => "3", "R4" => "4", "R5" => "5", "R6" => "6",
            "R7" => "7", "R8" => "8", "R9" => "9", "R10" => "10",
            "R11" => "11", "R12" => "12", "R13" => "13",
            "R14" => "14", "R15" => "15", "SCREEN" => "16384",
            "KBD" => "24576" }
var_count = 16

filename = ARGV.first
p = Parser.new(filename)

target = File.open(filename.split(".").first + ".hack", "w")

until p.no_more_commands?
  p.advance
  if p.command_type == "L_COMMAND"
    symbols[p.symbol] = p.line - 1
    p.line -= 1
  end
end

p.rewind

until p.no_more_commands?
  p.advance
  next if p.command_type == "L_COMMAND"
  if p.command_type == "C_COMMAND"
    target.write("111")
    target.write COMP[p.comp]
    target.write DEST[p.dest]
    target.write JUMP[p.jump]
  elsif p.symbol.numeric?
    target.write("%016b" % p.symbol.to_i)
  else
    unless symbols.include?(p.symbol)
      symbols[p.symbol] = var_count
      var_count += 1
    end
    target.write("%016b" % symbols[p.symbol].to_i)
  end
  target.write("\n")
end
target.close

