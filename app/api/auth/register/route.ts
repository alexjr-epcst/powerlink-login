import { type NextRequest, NextResponse } from "next/server"
import { registerConsumer } from "@/lib/auth"

export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    const { accountNumber, fullName, email, phone, password } = data

    if (!accountNumber || !fullName || !email || !phone || !password) {
      return NextResponse.json({ error: "Missing required fields" }, { status: 400 })
    }

    if (password.length < 8) {
      return NextResponse.json({ error: "Password must be at least 8 characters long" }, { status: 400 })
    }

    const result = await registerConsumer(data)

    if (!result.success) {
      return NextResponse.json({ error: result.message }, { status: 400 })
    }

    return NextResponse.json({
      success: true,
      message: result.message,
    })
  } catch (error) {
    console.error("Registration error:", error)
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
