# frozen_string_literal: true

class BuffAlertFormat < EnumerateIt::Base
  associate_values(
    successful: /на Вас наложено благословение/,
    voices_exhausted: /для наложения социальных эффектов - требуется Голос Древних, получаемый при каждой победе над созданиями тьмы!/,
    ability_cooldown: /социальные эффекты можно накладывать только через определенное время после предыдущего!/,
    same_buff_in_effect: /на эту цель уже действует такое благословение!/,
    invalid_race: /Вы не являетесь апостолом этой расы!/,
    race_buff_in_effect: /на цель уже наложено другое расовое благословение!/
  )

  def self.successful?(type)
    type == key_for(SUCCESSFUL)
  end

  def self.unsuccessful_types
    [BuffAlertFormat::VOICES_EXHAUSTED,
     BuffAlertFormat::ABILITY_COOLDOWN,
     BuffAlertFormat::SAME_BUFF_IN_EFFECT,
     BuffAlertFormat::INVALID_RACE,
     BuffAlertFormat::RACE_BUFF_IN_EFFECT]
  end
end
