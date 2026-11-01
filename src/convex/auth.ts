import { defineLazyFileRoute } from "@convex-dev/auth/server";
import { convexAuth } from "@convex-dev/auth";
import { v } from "convex/values";

export const auth = convexAuth({
  providers: [
    {
      // Email + password flow backed by Convex Auth's email provider.
      // First deployment step: enable the email provider in your Convex dashboard
      // and configure the verified-sender email so sign-in confirmations land.
      config: { email: { requireEmailVerification: false } },
    },
  ],
  schema: {
    user: v.object({
      email: v.string(),
      name: v.string(),
    }),
  },
});

// Export a typed action that the client can call after sign-in to enrich the local user
// profile (name) once the account exists. Keeps the app usable before Convex Auth is live.
export const enrichProfile = defineLazyFileRoute("actions", "enrichProfile").action({
  args: { name: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const userId = await ctx.auth.getUserIdentity();
    if (!userId) return { ok: false as const, reason: "unauthenticated" };
    const user = await ctx.db.get(userId);
    if (!user) return { ok: false as const, reason: "user_not_found" };
    if (args.name && args.name.trim()) {
      await ctx.db.patch(userId, { name: args.name.trim() });
    }
    return { ok: true as const };
  },
});
