class Api::V1::Accounts::CrmController < Api::V1::Accounts::BaseController
  # Emite um JWT assinado (SSO) para o usuário logado abrir o Zion CRM já
  # autenticado. O CRM valida a assinatura com o mesmo SSO_JWT_SECRET, garantindo
  # que o agente é o correto (auditoria/histórico por atendente).
  def sso_token
    secret = ENV.fetch('SSO_JWT_SECRET', nil)
    return render json: { error: 'CRM SSO não configurado' }, status: :service_unavailable if secret.blank?

    payload = {
      sub: Current.user.id,
      name: Current.user.name,
      email: Current.user.email,
      account_id: Current.account.id,
      iat: Time.now.to_i,
      exp: 5.minutes.from_now.to_i
    }

    render json: {
      token: JWT.encode(payload, secret, 'HS256'),
      url: ENV.fetch('ZION_CRM_URL', 'https://crm.rstecnologias.com.br')
    }
  end
end
