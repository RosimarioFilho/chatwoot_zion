# Apps companheiros da Zion habilitados por conta (Zion Leads / Captar).
#
# Nao dao para virar feature flags do Chatwoot: `accounts.feature_flags` e um
# bigint e o FlagShihTzu usa o bit 2^(N-1) para a feature de indice N. Com as 63
# features que o Chatwoot ja tem, o teto do bigint com sinal esta batido -- a 64a
# feature estoura a coluna e todo UPDATE na conta vira 500. Ficam entao em
# `custom_attributes`, que e jsonb e nao tem esse limite.
#
# O payload da conta expoe os dois junto de `features`, para o front consultar
# pelo mesmo caminho de sempre (`isFeatureEnabledonAccount`).
module ZionAppable
  extend ActiveSupport::Concern

  APPS = {
    'zion_crm' => 'Zion Leads (CRM)',
    'zion_captar' => 'Captar (Força de Vendas)'
  }.freeze

  def zion_app_enabled?(name)
    return false unless APPS.key?(name.to_s)

    custom_attributes.to_h[name.to_s] == true
  end

  # Hash no mesmo formato de `all_features`, com todos os apps e seu estado.
  def zion_apps
    APPS.keys.index_with { |name| zion_app_enabled?(name) }
  end

  # Recebe a lista de apps marcados no Super Admin; o que nao vier fica desligado.
  def selected_zion_apps=(names)
    enabled = Array(names).map(&:to_s)
    self.custom_attributes = custom_attributes.to_h.merge(
      APPS.keys.index_with { |name| enabled.include?(name) }
    )
  end
end
