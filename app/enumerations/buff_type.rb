# frozen_string_literal: true

class BuffType < EnumerateIt::Base
  associate_values(
    human: 0, # "ч"
    elf: 1, # "э"
    daemon: 2, # "д"
    undead: 3, # "н"
    orc: 4, # "о"
    goblin: 5, # "г"
    dwarf: 6, # "м"
    attack: 7, # "а"
    defence: 8, # "з"
    fortune: 9 # "у"
  )

  CHAR_TO_BUFF = {
    'ч' => HUMAN,
    'э' => ELF,
    'д' => DAEMON,
    'н' => UNDEAD,
    'о' => ORC,
    'г' => GOBLIN,
    'м' => DWARF,
    'а' => ATTACK,
    'з' => DEFENCE,
    'у' => FORTUNE
  }.freeze

  STRING_TO_BUFF = {
    'человека' => HUMAN,
    'эльфов' => ELF,
    'демонов' => DAEMON,
    'нежити' => UNDEAD,
    'орков' => ORC,
    'гоблинов' => GOBLIN,
    'гномов' => DWARF,
    'атаки' => ATTACK,
    'защиты' => DEFENCE,
    'удачи' => FORTUNE
  }.freeze

  def self.race_buffs
    [
      BuffType::HUMAN,
      BuffType::ELF,
      BuffType::DAEMON,
      BuffType::UNDEAD,
      BuffType::ORC,
      BuffType::GOBLIN,
      BuffType::DWARF
    ]
  end

  def self.standard_buffs
    [
      BuffType::ATTACK,
      BuffType::DEFENCE,
      BuffType::FORTUNE
    ]
  end

  def self.chars_to_types(chars)
    enumerated_buff_types = chars.map{ |char| CHAR_TO_BUFF[char] }

    { race_buff: enumerated_buff_types.find { |buff| race_buffs.include?(buff) },
      standard_buffs: enumerated_buff_types.find_all { |buff| standard_buffs.include?(buff) } }
  end

  def self.string_to_types(string)
    STRING_TO_BUFF[string]
  end
end
