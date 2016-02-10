module Sprouter
  class PF
    class Test
      def tables
        ["turbo_hosts", "turbo_sites"]
      end

      def table_entries(table)
        []
      end

      def set_table(table, ips)
      end

      def flush_table(table)
      end
    end

    def tables
      @tables ||= read_tables
    end

    def table_entries(table)
      @table_entries ||= Hash.new { |h, table| h[table] = read_table(table) }
      @table_entries[table]
    end

    def set_table(table, ips)
      current_ips = table_entries(table)
      purge_ips = current_ips - ips
      system "pfctl", "-t", table, "-T", "add", *ips
      if purge_ips.any?
        system "pfctl", "-t", table, "-T", "delete", *purge_ips
      end
      @table_entries[table] = read_table(table)
    end

    def flush_table(table)
      system "pfctl", "-t", table, "-T", "flush"
      @table_entries[table] = read_table(table)
    end

    private

    def read_tables
      lines "pfctl", "-s", "Tables"
    end

    def read_table(table)
      lines "pfctl", "-t", table, "-T", "show"
    end

    def lines(*cmd)
      IO.popen(cmd) { |pf| pf.each_line.map(&:strip) }
    end
  end
end
