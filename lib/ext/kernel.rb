require "native"

module Kernel
  def node_require(*args)
    Native(`require`.call(*args))
  end

  def system(cmd, *args)
    cp = node_require("child_process")
    params = { stdio: :inherit, shell: args.empty? }
    result = cp.spawnSync(cmd, args, params.to_n)
    result["status"].zero?
  end
end
