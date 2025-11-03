export interface User {
  id: string
  accountNumber?: string
  username?: string
  email: string
  fullName: string
  role: "admin" | "consumer"
}

export interface LoginCredentials {
  identifier: string // account number for consumers, username for admin
  password: string
}

export interface RegisterData {
  accountNumber: string
  fullName: string
  email: string
  phone: string
  password: string
}

// Mock user data - replace with database queries
const mockUsers = {
  // Admin users
  admin: {
    id: "admin-1",
    username: "admin",
    email: "admin@powerlink-bapa.com",
    fullName: "System Administrator",
    role: "admin" as const,
    passwordHash: "powerlink2025", // In real app, this would be hashed
  },
  // Consumer users
  C001: {
    id: "consumer-1",
    accountNumber: "C001",
    email: "juan.delacruz@email.com",
    fullName: "Juan dela Cruz",
    role: "consumer" as const,
    passwordHash: "password123",
  },
  C002: {
    id: "consumer-2",
    accountNumber: "C002",
    email: "maria.santos@email.com",
    fullName: "Maria Santos",
    role: "consumer" as const,
    passwordHash: "password123",
  },
  C003: {
    id: "consumer-3",
    accountNumber: "C003",
    email: "pedro.garcia@email.com",
    fullName: "Pedro Garcia",
    role: "consumer" as const,
    passwordHash: "password123",
  },
}

// Available account numbers for registration
const availableAccountNumbers = ["C004", "C005", "C006", "C007", "C008", "C009", "C010"]

const verificationCodes = new Map<string, { code: string; timestamp: number }>()

export async function authenticateUser(
  credentials: LoginCredentials,
  expectedRole?: "admin" | "consumer",
): Promise<User | null> {
  console.log("[v0] Authenticating user with identifier:", credentials.identifier)

  // Check if it's an admin login (username-based)
  if (credentials.identifier === "admin") {
    const adminUser = mockUsers.admin
    if (adminUser.passwordHash === credentials.password) {
      if (expectedRole && expectedRole !== "admin") {
        console.log("[v0] Admin trying to login on consumer page")
        return null
      }
      console.log("[v0] Admin authentication successful")
      return {
        id: adminUser.id,
        username: adminUser.username,
        email: adminUser.email,
        fullName: adminUser.fullName,
        role: adminUser.role,
      }
    }
    console.log("[v0] Admin authentication failed")
    return null
  }

  // For consumers, check mock users first
  const mockUser = mockUsers[credentials.identifier as keyof typeof mockUsers]
  if (mockUser && mockUser.passwordHash === credentials.password) {
    if (expectedRole && expectedRole !== "consumer") {
      console.log("[v0] Consumer trying to login on admin page")
      return null
    }
    console.log("[v0] Consumer authentication successful")
    return {
      id: mockUser.id,
      accountNumber: mockUser.accountNumber,
      email: mockUser.email,
      fullName: mockUser.fullName,
      role: "consumer",
    }
  }

  console.log("[v0] Authentication failed for identifier:", credentials.identifier)
  return null
}

export async function registerConsumer(data: RegisterData): Promise<{ success: boolean; message: string }> {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 2000))

  // Check if account number is valid and available
  if (!availableAccountNumbers.includes(data.accountNumber)) {
    return {
      success: false,
      message: "Invalid account number. Please check with the administrator.",
    }
  }

  // Check if account number is already registered
  if (mockUsers[data.accountNumber as keyof typeof mockUsers]) {
    return {
      success: false,
      message: "This account number is already registered.",
    }
  }

  // In a real app, you would:
  // 1. Hash the password
  // 2. Save to database
  // 3. Send confirmation email

  return {
    success: true,
    message: "Account created successfully!",
  }
}

export function isValidAccountNumber(accountNumber: string): boolean {
  return availableAccountNumbers.includes(accountNumber) || Object.keys(mockUsers).includes(accountNumber)
}

export function getStoredAuth(): { type: "admin" | "consumer" | null; user: any } {
  if (typeof window === "undefined") return { type: null, user: null }

  const adminToken = localStorage.getItem("admin_token")
  const consumerToken = localStorage.getItem("consumer_token")

  if (adminToken) {
    return {
      type: "admin",
      user: {
        name: "System Administrator",
        role: "admin",
      },
    }
  }

  if (consumerToken) {
    const name = localStorage.getItem("consumer_name")
    const account = localStorage.getItem("consumer_account")
    return {
      type: "consumer",
      user: {
        name: name || "",
        accountNumber: account || "",
        role: "consumer",
      },
    }
  }

  return { type: null, user: null }
}

export function logout(): void {
  if (typeof window === "undefined") return

  localStorage.removeItem("admin_token")
  localStorage.removeItem("consumer_token")
  localStorage.removeItem("consumer_name")
  localStorage.removeItem("consumer_account")
}

export interface PasswordResetRequest {
  email: string
  verificationCode: string
  newPassword: string
}

export async function requestPasswordReset(email: string): Promise<{ success: boolean; message: string }> {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 1000))

  // Check if email exists in mock users
  const userExists = Object.values(mockUsers).some((user) => user.email === email)

  if (!userExists) {
    // For security, don't reveal if email exists
    return {
      success: true,
      message: "If an account exists with this email, a verification code has been sent.",
    }
  }

  // Generate 6-digit verification code
  const code = Math.floor(100000 + Math.random() * 900000).toString()
  verificationCodes.set(email, { code, timestamp: Date.now() })

  // In production, send email with verification code
  console.log(`[v0] Password reset code for ${email}: ${code}`)

  return {
    success: true,
    message: "Verification code sent to your email.",
  }
}

export async function verifyResetCode(email: string, code: string): Promise<boolean> {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 500))

  const stored = verificationCodes.get(email)
  if (!stored) return false

  // Check if code is expired (15 minutes)
  const isExpired = Date.now() - stored.timestamp > 15 * 60 * 1000
  if (isExpired) {
    verificationCodes.delete(email)
    return false
  }

  return stored.code === code
}

export async function resetPassword(
  email: string,
  newPassword: string,
): Promise<{ success: boolean; message: string }> {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 1000))

  // Find user by email
  const userEntry = Object.entries(mockUsers).find(([_, user]) => user.email === email)

  if (!userEntry) {
    return {
      success: false,
      message: "User not found.",
    }
  }

  // In production, hash the password and update in database
  const [key, user] = userEntry
  mockUsers[key as keyof typeof mockUsers].passwordHash = newPassword

  // Clear verification code
  verificationCodes.delete(email)

  console.log(`[v0] Password reset successful for ${email}`)

  return {
    success: true,
    message: "Password has been reset successfully.",
  }
}

async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(password)
  const hashBuffer = await crypto.subtle.digest("SHA-256", data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("")
  return hashHex
}
