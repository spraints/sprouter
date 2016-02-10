module Sprouter
  class PF
    def tables
      @tables ||= read_tables
    end

    def table_entries(table)
      @table_entries ||= Hash.new { |h, table| h[table] = load_table(table) }
    end

    private

    def load_tables
      lines "pfctl", "-s", "Tables"
    end

    def load_table(table)
      lines "pfctl", "-t", table, "-T", "show"
    end
  end
end
