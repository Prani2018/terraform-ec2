import jenkins.model.*
import hudson.tools.*
import hudson.tasks.Maven.MavenInstallation

/**
 * Jenkins Groovy Script to Configure Maven Tool
 * Run this in: Manage Jenkins -> Script Console
 */

def jenkins = Jenkins.getInstance()

// Maven tool configuration
def mavenConfig = [
    name: "localMaven",
    home: "/opt/maven",
    properties: []  // No additional properties needed for manual installation
]

try {
    // Get the Maven tool descriptor
    def mavenDescriptor = jenkins.getDescriptorByType(MavenInstallation.DescriptorImpl.class)
    
    // Get existing Maven installations
    def existingInstallations = mavenDescriptor.getInstallations()
    
    // Check if our Maven installation already exists
    def existingMaven = existingInstallations.find { it.name == mavenConfig.name }
    
    if (existingMaven != null) {
        println("⚠️  Maven tool '${mavenConfig.name}' already exists at: ${existingMaven.home}")
        println("💡 Current configuration:")
        println("   - Name: ${existingMaven.name}")
        println("   - Home: ${existingMaven.home}")
        return
    }
    
    println("🔧 Creating Maven tool configuration...")
    
    // Create new Maven installation
    def newMavenInstallation = new MavenInstallation(
        mavenConfig.name,           // Name
        mavenConfig.home,           // Home directory
        mavenConfig.properties as List<ToolProperty<?>>  // Properties
    )
    
    // Add the new installation to existing ones
    def updatedInstallations = existingInstallations + newMavenInstallation
    
    // Update the descriptor with new installations
    mavenDescriptor.setInstallations(updatedInstallations as MavenInstallation[])
    
    // Save the configuration
    mavenDescriptor.save()
    jenkins.save()
    
    println("✅ Maven tool '${mavenConfig.name}' created successfully!")
    println("📋 Configuration Details:")
    println("   - Name: ${mavenConfig.name}")
    println("   - Home: ${mavenConfig.home}")
    println("   - Type: Manual Installation")
    
    println("\n📊 All configured Maven installations:")
    mavenDescriptor.getInstallations().each { installation ->
        println("   - ${installation.name} → ${installation.home}")
    }
    
    println("\n💡 Usage in Pipeline:")
    println("tools {")
    println("    maven '${mavenConfig.name}'")
    println("}")

} catch (Exception e) {
    println("❌ Error configuring Maven tool: ${e.message}")
    e.printStackTrace()
}
