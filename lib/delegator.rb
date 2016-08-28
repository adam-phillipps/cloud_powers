module Smash
  modul Delegator
    def build_job(id, opts)
      type = opts.delete(:type)
      if approved_job? type
        eval("#{type}.new(opts)")
      else
        DefaultTask.new(id, opts)
    end

    def approved_task?(type = nil)
      # TODO:
      # - find a way to verify the validity of the job type.
      #   - this could be a dynamo table or a config file that
      #     gets deployed, etc.
      #   - The info that you need is the name of the job type
      #     - possible convention:
      #         Approved_jobs: {
      #           FredsScraping,
      #           OverstockSales,
      #           etc
      #         }

      type.nil?
    end
  end
end
