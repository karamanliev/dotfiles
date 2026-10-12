import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "switch-agent",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "switch_agent",
        description:
          "Switch this session between Plan and Build only when the user explicitly requests it. The change applies to subsequent model requests; it does not change the selected model.",
        input: {
          type: "object",
          properties: {
            agent: {
              type: "string",
              enum: ["plan", "build"],
              description: "The agent requested by the user.",
            },
          },
          required: ["agent"],
          additionalProperties: false,
        },
        options: { codemode: false },
        async execute(input, context) {
          const { agent } = input as { agent: "plan" | "build" }
          if (agent !== "plan" && agent !== "build") {
            throw new Error("Agent must be plan or build.")
          }

          await ctx.session.switchAgent({ sessionID: context.sessionID, agent })
          return {
            content: `Switched this session to ${agent}. The change applies to subsequent model requests.`,
          }
        },
      })
    })
  },
})
