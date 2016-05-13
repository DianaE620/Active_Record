
class User < ActiveRecord::Base
# Implementa los métodos y validaciones de tu modelo aquí. 
  validates :email, uniqueness: true, format: { with: /\A\w{1,}@\w{1,}.\w{2,}/ ,
    message: "not valid" }

  # validates :email, uniqueness: true

  # validates :birthday, presence: true, if: :adult
  validate :adult

  validate :phone_validate

  def name
    nombre = self.first_name 
    apellido = self.last_name
    nombre + " " + apellido
  end

  def age
    años = Date.today.year - self.birthday.year 
    mes = Date.today.month
    mes_user = self.birthday.month

    if mes > mes_user
      años
    else
      años + 1
    end 
  end


  def adult
    if age < 18
      errors.add(:birthday, "edad incorrecta")
    end
  end

  def phone_validate
    i = 0

    phone.each_char do |s|
      s =~ /\d/ ? i += 1 : false
    end

    if i < 10
      errors.add(:phone, "numero invalido")
    end

  end

end








