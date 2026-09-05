require 'administrate/field/base'

# Checkboxes dos apps companheiros da Zion no Super Admin. Ver ZionAppable para
# o porque de nao serem feature flags do Chatwoot.
class ZionAppsField < Administrate::Field::Base
  def to_s
    data
  end

  def apps
    ZionAppable::APPS
  end
end
