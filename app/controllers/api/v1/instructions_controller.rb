class Api::V1::InstructionsController < ApplicationController

    def show
        @instruction = Instruction.find(params[:id])
        render json: @instruction
    end

    def index
        @instructions = Instruction.all
        render json: @instructions
    end

end
