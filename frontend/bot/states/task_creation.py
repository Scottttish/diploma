from aiogram.fsm.state import State, StatesGroup


class RegistrationStates(StatesGroup):
    waiting_for_phone = State()


class TaskCreationStates(StatesGroup):
    choose_service_type = State()
    describe_problem    = State()
    enter_address       = State()
    confirm             = State()


class TaskStatusStates(StatesGroup):
    waiting_for_id = State()
