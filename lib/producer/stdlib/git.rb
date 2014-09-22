module Producer
  module STDLib
    module Git
      STDLib.define_test :git? do |path|
        dir? "#{path}/.git"
      end

      STDLib.define_macro :git_clone do |repository, destination|
        condition { no_git? destination }

        sh "git clone --depth 1 #{repository} #{destination}"
      end

      STDLib.define_macro :git_update do |path|
        git = "git -C #{path}"

        sh "#{git} fetch origin"
        sh "#{git} reset --hard origin"
      end
    end
  end
end
