class Chef
  class Resource
    class Template
      def bcrypt(password)
        shell_out!(%{htpasswd -nbBC 10 username #{password} | cut -d ':' -f 2 | tr -d "\n"}).stdout
      end
    end
  end
end
