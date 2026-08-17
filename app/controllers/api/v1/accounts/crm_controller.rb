class Api::V1::Accounts::CrmController < Api::V1::Accounts::BaseController
  # Emite um JWT assinado (SSO) para o usuário logado abrir o Zion CRM já
  # autenticado. O CRM valida a assinatura com o mesmo SSO_JWT_SECRET e checa
  # issuer/audience/scope/jti (anti-replay), garantindo que o agente é o correto
  # (auditoria/histórico por atendente).
  def sso_token
    secret = ENV.fetch('SSO_JWT_SECRET', nil)
    return render json: { error: 'CRM SSO não configurado' }, status: :service_unavailable if secret.blank?

    now = Time.now.to_i
    payload = {
      iss: 'zion',
      aud: 'zion-crm',
      sub: Current.user.id.to_s,
      name: Current.user.name,
      email: Current.user.email,
      account_id: Current.account.id,
      scope: 'crm:session',
      jti: SecureRandom.uuid,
      iat: now,
      exp: now + 90
    }

    render json: {
      token: JWT.encode(payload, secret, 'HS256'),
      url: ENV.fetch('ZION_CRM_URL', 'https://crm.rstecnologias.com.br')
    }
  end
end
