# Use the latest PowerShell image from Microsoft
FROM mcr.microsoft.com/powershell:latest

# Set build arguments for user creation
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Switch to root user to set up the environment
USER root

# Install basic development dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl python3 python3-pip sudo && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install aider using pip
RUN python3 -m pip install aider-chat

# Create a non-root user with sudo privileges
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set up PowerShell as the default shell
SHELL ["pwsh", "-Command"]

# Set the working directory
WORKDIR /workspace
