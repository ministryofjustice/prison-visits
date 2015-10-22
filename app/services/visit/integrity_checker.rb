class Visit
  module IntegrityChecker
    def ensure_visit_integrity
      return if required_information?
      log_any_missing_information
      flash[:notice] = I18n.t(
        :ensure_visit_integrity,
        scope: 'controllers.shared'
      )
      redirect_to edit_prisoner_details_path
    end

    def required_information?
      visit && visit.prisoner? && visit.prison_name?
    end

    def log_any_missing_information
      prefix = "Visit #{visit.visit_id} is missing a"
      log_missing_prisoner(prefix)
      log_missing_prisoner_number(prefix)
      log_missing_prison_name(prefix)
      log_missing_prison(prefix)
      log_missing_prison_slots(prefix)
    end

    private

    def log_missing_prisoner(prefix)
      unless visit.prisoner?
        Rails.logger.info("#{prefix} prisoner")
      end
    end

    def log_missing_prisoner_number(prefix)
      if visit.prisoner? && !visit.prisoner_number?
        Rails.logger.info("#{prefix} prisoner number")
      end
    end

    def log_missing_prison_name(prefix)
      if visit.prison? && !visit.prison_name?
        Rails.logger.info("#{prefix} prison name")
      end
    end

    def log_missing_prison(prefix)
      if visit.prisoner? && !visit.prison?
        Rails.logger.info("#{prefix} prison")
      end
    end

    def log_missing_prison_slots(prefix)
      if visit.prison? && !visit.prison_slots?
        Rails.logger.info("#{prefix} prison with slots")
      end
    end
  end
end
