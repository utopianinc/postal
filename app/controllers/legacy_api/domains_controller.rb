# app/controllers/legacy_api/domains_controller.rb
module LegacyAPI
  class DomainsController < BaseController
    def verify_dns
      @domain = Domain.find_by(uuid: params[:id])

      unless @domain
        return render json: { status: "error", message: "Domain not found" }, status: :not_found
      end

      if @domain.verified?
        return render json: { status: "success", message: "Domain is already verified." }, status: :ok
      end

      if @domain.verify_with_dns
        render json: { status: "success", message: "Domain verified successfully via DNS." }, status: :ok
      else
        render json: { status: "error", message: "DNS verification failed. Please ensure the correct DNS records are set up and try again." }, status: :unprocessable_entity
      end
    end

    def create
      # Assuming that domain creation parameters are provided in the request body as JSON
      domain_params = params.require(:domain).permit(:name, :verification_method)
      @domain = (@server ? @server.domains : current_organization.domains).build(domain_params)

      if @domain.save
        render_success(domain_id: @domain.id)
      else
        render_error("DomainCreationFailed", { errors: @domain.errors.full_messages })
      end
    end

    def destroy
      @domain = Domain.find_by(uuid: params[:id])

      unless @domain
        return render json: { status: "error", message: "Domain not found" }, status: :not_found
      end

      if @domain.destroy
        render json: { status: "success", message: "Domain deleted successfully." }, status: :ok
      else
        render json: { status: "error", message: "Failed to delete domain." }, status: :unprocessable_entity
      end
    end

    def check
      if @domain.check_dns(:manual)
        render json: { status: "success", message: "DNS settings are correct." }, status: :ok
      else
        render json: { status: "error", message: "DNS settings are incorrect." }, status: :unprocessable_entity
      end
    end
  end
end
