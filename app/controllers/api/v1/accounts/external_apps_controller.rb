# Emite um JWT curto (SSO) para o agente logado abrir um app companheiro da Zion
# ja autenticado, dentro de um iframe. O app companheiro valida a assinatura com
# o mesmo segredo e checa issuer/audience/scope/jti (anti-replay), garantindo que
# o agente e o correto (auditoria/historico por atendente).
#
# Cada conta escolhe quais apps usa nos checkboxes do Super Admin
# (zion_crm / zion_captar, ver ZionAppable) - o menu na sidebar segue o mesmo
# estado.
class Api::V1::Accounts::ExternalAppsController < Api::V1::Accounts::BaseController
  APPS = {
    'crm' => {
      key: 'zion_crm',
      audience: 'zion-crm',
      scope: 'crm:session',
      url_env: 'ZION_CRM_URL',
      default_url: 'https://crm.rstecnologias.com.br',
      secret_env: 'CRM_JWT_SECRET'
    },
    'captar' => {
      key: 'zion_captar',
      audience: 'zion-captar',
      scope: 'captar:session',
      url_env: 'ZION_CAPTAR_URL',
      default_url: 'https://captar.rstecnologias.com.br',
      secret_env: 'CAPTAR_JWT_SECRET'
    }
  }.freeze

  TOKEN_TTL = 90 # segundos - so precisa sobreviver ao redirect do /sso

  before_action :set_app

  def sso_token
    return render json: { error: 'App nao habilitado para esta conta' }, status: :forbidden unless app_enabled?
    return render json: { error: 'SSO nao configurado' }, status: :service_unavailable if secret.blank?

    render json: {
      token: JWT.encode(payload, secret, 'HS256'),
      url: ENV.fetch(@app[:url_env], @app[:default_url])
    }
  end

  private

  def set_app
    @app = APPS[params[:app_key]]
    render json: { error: 'App desconhecido' }, status: :not_found if @app.blank?
  end

  def app_enabled?
    Current.account.zion_app_enabled?(@app[:key])
  end

  # Segredo proprio do app quando definido; senao o segredo compartilhado da Zion.
  def secret
    @secret ||= ENV.fetch(@app[:secret_env], nil).presence || ENV.fetch('SSO_JWT_SECRET', nil)
  end

  def payload
    now = Time.now.to_i
    {
      iss: 'zion',
      aud: @app[:audience],
      sub: Current.user.id.to_s,
      name: Current.user.name,
      email: Current.user.email,
      account_id: Current.account.id,
      scope: @app[:scope],
      jti: SecureRandom.uuid,
      iat: now,
      exp: now + TOKEN_TTL
    }
  end
end
